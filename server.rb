class MinecraftServer
  attr_accessor :path
  attr_accessor :id
  attr_accessor :status
  def initialize(path='server')
    @status = {:state => 'STOPPED'}
    @path = File.join(Dir.pwd,path)
  end
  def start(version)
    if @status[:state] != 'RUNNING'
      Dir.chdir(@path) do
        jar = "jar/#{version}.jar"
        @pid = IO.popen("java -Xmx1024M -Xms1024M -jar #{jar} nogui").pid
      end
      @status[:state] = 'RUNNING'
      @status[:version] = version
    end
  end
  def stop
    if @status[:state] == 'RUNNING'
      Process.kill("TERM",@pid)
      Process.wait(@pid)
      @status[:state] = 'STOPPED'
    end
  end
  def backup
    Dir.chdir(@path) do
      system "zip -r 'world_#{Time.now.strftime('%m%d%Y_%H%M.zip')}' world"
    end
  end
  def restore(file)
    Dir.chdir(@path) do
      if File.exist?(file)
        system "rm -rf world.old"
        system "mv world world.old"
        system "unzip '#{file}'"
      end
    end
  end
  def delete_backup(file)
    Dir.chdir(@path) do
      if File.exist?(file)
        system "rm -f '#{file}'"
      end
    end
  end
  def op(player)
    Dir.chdir(@path) do
      ops = File.open('ops.txt') do |f| f.read.split end
      unless ops.include? player
        ops << player
        File.open('ops.txt','w') do |f| f.write(ops.join("\n")) end
      end
    end
  end
  def deop(player)
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
      `ls world/players/*.dat`.split.map {|f| File.basename(f)[0...-4]}
    end
  end
  def ops
    Dir.chdir(@path) do
      File.open('ops.txt') do |f| f.read.split end
    end
  end
  def versions
    Dir.chdir(@path) do
      `ls jar/*.jar`.split.map {|f| File.basename(f)[0...-4]}
    end
  end
end