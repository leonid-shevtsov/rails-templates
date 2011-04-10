require 'erb'
require 'yaml'
require 'fileutils'

def yes?(prompt)
  print prompt+' [Yn]'
  return ['Y','y','yes',''].include?(STDIN.gets.strip)
end

def prompt(prompt, default='')
  print "#{prompt} [#{default}]: "
  result = STDIN.gets.strip
  result=='' ? default : result
end

def run(command)
  "print -- running #{command}"
  system command
end

FEATURES = %w(compass russian)

TEMPLATE_PATH = ARGV[1]

CONFIG = {
  :app_name => ARGV[0],
  :app_module_name => ARGV[0].gsub(/(^|_)(\w)/) {|m| $2.upcase},
  :features => {},
}

CONFIG[:capistrano] = {
  :rvm_ruby_string => `rvm list default string`.strip+'@'+CONFIG[:app_name],
  :user => 'USER',
  :repository => 'REPOSITORY_URL',
  :server => 'SERVER'
}


FEATURES.each {|f| CONFIG[:features][f.to_sym] = yes?("Include #{f}?")}

CONFIG[:capistrano].keys.each do |key|
  CONFIG[:capistrano][key] = prompt("Capistrano #{key}", CONFIG[:capistrano][key])
end

# a little cleanup
system 'mv config/database.yml config/database.yml.sample'
YAML.load_file(File.join(TEMPLATE_PATH, 'files_to_remove.yml')).each do |filename|
  run "rm -rf #{filename}"
end

# copy over files from the template
(Dir.glob(File.join(TEMPLATE_PATH, 'template', '**', '*'), File::FNM_DOTMATCH)).each do |filename|
  next if filename =~ /\.$/
  new_path = filename.gsub(/^#{TEMPLATE_PATH}\/template\//,'')
  if File.directory?(filename)
    if File.exists?(new_path)
      if File.directory?(new_path)
        puts "exists #{new_path}"
      else
        puts "ERROR - exists and not a directory: #{new_path}"
        exit
      end
    else
      puts " mkdir #{new_path}"
      `mkdir #{new_path}`
    end
  else
    if filename =~ /\.erb$/
      new_path.gsub!(/\.erb$/,'')
      puts "   erb #{new_path}"
      contents = ERB.new(File.read(filename)).result
    else
      puts "  file #{new_path}"
      contents = File.read(filename)
    end
    File.open(new_path, 'w') {|f| f.write contents}
  end
end

# Download external dependencies
YAML.load_file(File.join(TEMPLATE_PATH, 'external.yml')).each do |filename, source|
  run "curl #{source} --location >#{filename}"
end

# All right! Ready to run some scripts

run 'bundle install'
run 'rake db:sessions:create'
run 'rake db:migrate:reset'

if CONFIG[:features][:compass]
  run 'bundle exec compass init rails . --sass-dir app/stylesheets --css-dir public/stylesheets'
end

# generate formtastic code
run 'bundle exec rails generate formtastic:install'
run 'mv public/stylesheets/formtastic.css app/stylesheets/_formtastic.scss'
run 'mv public/stylesheets/formtastic_changes.css app/stylesheets/_formtastic_changes.scss'

# test harness
run 'bundle exec rails generate rspec:install'

# Done! Let's get this all under version control
run 'git init'
