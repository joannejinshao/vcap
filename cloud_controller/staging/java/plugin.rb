
class JavaPlugin < StagingPlugin
  def framework
    'java'
  end 
 
  
  def copy_droplet_yaml(dir)
    resource_dir = File.join(File.dirname(__FILE__), 'resources')
    FileUtils.cp(File.join(resource_dir, "droplet.yaml"), dir)    
  end
  

  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      #webapp_root = Tomcat.prepare(destination_directory)
      copy_droplet_yaml(destination_directory)
      copy_source_files
      #Tomcat.configure_tomcat_application(destination_directory, webapp_root, self.autostaging_template, environment)  unless self.skip_staging(webapp_root)
      create_startup_script
    end
  end

 

  # We redefine this here because Tomcat doesn't want to be passed the cmdline
  # args that were given to the 'start' script.
  def start_command    
    full_jar_file = Dir.glob('app/*.jar').first
    jar_file = full_jar_file.split("/").last 
    state = "echo \"{\\\"state\\\": \\\"RUNNING\\\"}\" >> ../java.state"
    command = "#{state} \n java -jar #{jar_file}"
    if environment[:args]
      environment[:args].each  do |key, value|
        if key.to_s == "PORT" then
          command << " -port $PORT"
        else
          command << " -" << key.to_s << " " << value 
        end 
      end   
     
    end
=begin
    if environment[:args]
      if environment[:args][:PORT]
        command << " -port $PORT"
      end

      environment[:args].each  do |key, value|
        if key.to_s == "PORT" then
          command << " -port $PORT"
        else
          command << " " << key.to_s << " " << value
        end 
      end   
     
    end
=end  

    #return "#{state} \n java -jar #{jar_file} -port $PORT"
    command
  end

  

  private
  def startup_script
    vars = environment_hash    
    generate_startup_script(vars) do
      <<-SPRING
env > env.log
PORT=-1
while getopts ":p:" opt; do
  case $opt in
    p)
      PORT=$OPTARG
      ;;
  esac
done
if [ $PORT -lt 0 ] ; then
  echo "Missing or invalid port (-p)"
  exit 1
fi


      SPRING
    end
  end
end
