class JavaPlugin < StagingPlugin

  attr_accessor :suffix
  def framework
    'java'
  end

  def copy_resource(dir)
    resource_dir = File.join(File.dirname(__FILE__), 'resources')
    FileUtils.cp(File.join(resource_dir, "droplet.yaml"), dir)
    FileUtils.cp(File.join(resource_dir, "propogate_ports"), dir)
  end

  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      copy_resource(destination_directory)
      copy_source_files
      create_startup_script
    end
  end

  def start_command
    state = "echo \"{\\\"state\\\": \\\"RUNNING\\\"}\" >> ../java.state \n"    
    command = ""
    if(environment[:mainclass])
      app_runtime = environment[:mainclass][:app_runtime]
      lib_path = app_runtime[:lib_path]
      main = app_runtime[:main]
      search_path = "app/" + lib_path + "/*.jar"
      classpath = "."
      Dir.glob(search_path).each do |file|
        classpath += ":" + file[4..-1]
      end
      command = "#{state}java -classpath #{classpath} #{main}"      
    else
      full_jar_file = Dir.glob('app/*.jar').first
      jar_file = full_jar_file.split("/").last   
      command = "#{state}java -jar #{jar_file}"      
    end
    
    if environment[:args]
      environment[:args].each  do |key, value|
        command << " -" << key.to_s << " " << value
      end
    end
    command
  end

  private

  def startup_script

    vars = environment_hash
    @suffix = ""

    scriptEnv = <<-ENV
env > env.log
    ENV

    scriptPort = ""
    temp = ""
    if environment[:ports]
      defPart = ""
      opts = ":"
      casePart = ""
      missPart = ""
      destinationScript = ""

      environment[:ports].each do |port|
        portName = port[:port][:name]
        defPart += <<-DEFPART
#{portName}=-1
          DEFPART
        
        indexalpha = (port[:port][:index] + 97).chr
        
        opts += indexalpha + ":"
        casePart += <<-CASEPART
    #{indexalpha})
      #{portName}=$OPTARG
      ;;
        CASEPART
        missPart += <<-MISSPART
if [ $#{portName} -lt 0 ] ; then
  echo "Missing or invalid port (-#{indexalpha})"
  exit 1
fi
          MISSPART
        #destination = port[:destination]
        placeholder = port[:port][:placeholder]
        if(port[:port][:port_type]=="file")
          propogate_script = <<-PROP
ruby propogate_ports $#{portName} #{port[:port][:path]} #{placeholder[1..-1]}
              PROP
        destinationScript += propogate_script
        elsif(port[:port][:port_type]=="cmd")
          @suffix += "-#{portName} $#{portName}"
        end
      end

      whileFormer = <<-WHILEFORMER
while getopts "#{opts}" opt; do
  case $opt in
      WHILEFORMER
      whileLatter = <<-WHILELATTER
  esac
done
      WHILELATTER
    scriptPort = defPart + whileFormer + casePart + whileLatter + missPart + destinationScript
    end
    full_script = scriptEnv + scriptPort

    generate_startup_script(vars) do
      full_script
    end
  end

  def generate_startup_script(env_vars = {})
    after_env_before_script = block_given? ? yield : "\n"
    template = <<-SCRIPT
#!/bin/bash
<%= environment_statements_for(env_vars) %>
<%= after_env_before_script %>
<%= change_directory_for_start %>
<%= start_command %> #{@suffix} > ../logs/stdout.log 2> ../logs/stderr.log &
STARTED=$!
echo "$STARTED" >> ../run.pid
echo "#!/bin/bash" >> ../stop
echo "kill -9 $STARTED" >> ../stop
echo "kill -9 $PPID" >> ../stop
chmod 755 ../stop
wait $STARTED
    SCRIPT
    # TODO - ERB is pretty irritating when it comes to blank lines, such as when 'after_env_before_script' is nil.
    # There is probably a better way that doesn't involve making the above Heredoc horrible.
    ERB.new(template).result(binding).lines.reject {|l| l =~ /^\s*$/}.join
  end
end
