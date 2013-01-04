class MCServer
  attr_accessor :path
  attr_accessor :id
  attr_accessor :status
  def initialize(path='server')
    @status = {:state => 'Stopped'}
    @path = File.join(Dir.pwd,path)
    Dir.mkdir(@path) unless File.directory?(@path)
  end
  def start(version)
    raise 'File does not exist.' unless versions.include? version
    if @status[:state] != 'Running'
      Dir.chdir(@path) do
        jar = "jar/#{version}.jar"
        @pid = IO.popen("java -Xmx1024M -Xms1024M -jar #{jar} nogui").pid
      end
      @status[:state] = 'Running'
      @status[:version] = version
    end
  end
  def stop
    if @status[:state] == 'Running'
      Process.kill("TERM",@pid)
      Process.wait(@pid)
      @status[:state] = 'Stopped'
    end
  end
  def backup
    Dir.chdir(@path) do
      system "zip -r 'world_#{Time.now.strftime('%m%d%Y_%H%M.zip')}' world"
    end
  end
  def restore(file)
    raise 'File does not exist.' unless backups.include? file
    Dir.chdir(@path) do
      if File.exist?(file)
        system "rm -rf world.old"
        system "mv world world.old"
        system "unzip '#{file}'"
      end
    end
  end
  def delete_backup(file)
    raise 'File does not exist.' unless backups.include? file
    Dir.chdir(@path) do
      if File.exist?(file)
        system "rm -f '#{file}'"
      end
    end
  end
  def op(player)
    raise 'Player does not exist.' unless players.include? player
    Dir.chdir(@path) do
      ops = File.open('ops.txt') do |f| f.read.split end
      unless ops.include? player
        ops << player
        File.open('ops.txt','w') do |f| f.write(ops.join("\n")) end
      end
    end
  end
  def deop(player)
    raise 'Player does not exist.' unless ops.include? player
    Dir.chdir(@path) do
      ops = File.open('ops.txt') do |f| f.read.split end
      if ops.include? player
        ops.reject!{|op| op==player}
        File.open('ops.txt','w') do |f| f.write(ops.join("\n")) end
      end
    end
  end
  def backups
    Dir.chdir(@path) do
      `ls world_*.zip`.split
    end
  end
  def players
    Dir.chdir(@path) do
      begin
        `ls world/players/*.dat`.split.map {|f| File.basename(f)[0...-4]}
      rescue Errno::ENOENT
        Dir.mkdir('world/players')
        retry
      end
    end
  end
  def ops
    Dir.chdir(@path) do
      begin
        File.open('ops.txt') do |f| f.read.split end
      rescue Errno::ENOENT
        File.open('ops.txt','w') { }
        retry
      end
    end
  end
  def versions
    Dir.chdir(@path) do
      begin
        `ls jar/*.jar`.split.map {|f| File.basename(f).gsub(/\.jar$/,'')}.reverse
      rescue Errno::ENOENT
        Dir.mkdir('jar')
        retry
      end
    end
  end
end
