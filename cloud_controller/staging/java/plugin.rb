class JavaPlugin < StagingPlugin
  
  attr_accessor :suffix
  
  def framework
    'java'
  end

  def copy_resource(dir)
    resource_dir = File.join(File.dirname(__FILE__), 'resources')
    FileUtils.cp(File.join(resource_dir, "droplet.yaml"), dir)
    FileUtils.cp(File.join(resource_dir, "propogate_requirements"), dir)
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
    full_jar_file = Dir.glob('app/*.jar').first
    jar_file = full_jar_file.split("/").last
    state = "echo \"{\\\"state\\\": \\\"RUNNING\\\"}\" >> ../java.state \n"
    command = "#{state}java -jar #{jar_file}"
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
    if environment[:requirements]
      defPart = ""
      opts = ":"
      casePart = ""
      missPart = ""
      destinationScript = ""

      environment[:requirements].each do |requirement|
        temp += requirement.to_s
        if requirement[:type].to_s == "port" then
          portName = requirement[:name]
          defPart += <<-DEFPART
#{portName}=-1
          DEFPART
          if(requirement[:index]=="0")
            indexalpha ='p'
          else
            indexalpha = (requirement[:index].to_i + 96).chr
          end
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
          destinations = requirement[:destinations]
          destinations.each do |destination|
            if(destination[:type]=="xml")
              propogate_script = <<-PROP
ruby propogate_requirements $#{portName} #{destination[:path]} #{destination[:xpath]}
              PROP
            destinationScript += propogate_script
            elsif(destination[:type]=="cmd")
              @suffix += "-#{portName} $#{portName}"
            end
          end
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
