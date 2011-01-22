require 'erb'
require 'yaml'
require 'fileutils'

def yes?(prompt)
  print prompt+' [Yn]'
  return ['Y','y','yes',''].include?(STDIN.gets.strip)
end

FEATURES = %w(compass cucumber russian)

TEMPLATE_PATH = ARGV[1]

CONFIG = {
  :app_name => ARGV[0],
  :app_module_name => ARGV[0].gsub(/(^|_)(\w)/) {|m| $2.upcase},
  :features => {}
}

FEATURES.each {|f| CONFIG[:features][f.to_sym] = yes?("Include #{f}?")}

# a little cleanup
`mv config/database.yml config/database.yml.sample`
YAML.load_file(File.join(TEMPLATE_PATH, 'files_to_remove.yml')).each do |filename|
  `rm -rf #{filename}`
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
      puts "    erb #{new_path}"
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
  `curl #{source} --location >#{filename}`
end

# All right! Ready to run some scripts

`bundle install`
`rake db:sessions:create`
`rake db:migrate:reset`

if CONFIG[:features][:compass]
  `bundle exec compass init rails . --sass-dir app/stylesheets --css-dir public/stylesheets`
end

# generate formtastic code
`bundle exec rails generate formtastic:install`
`mv public/stylesheets/formtastic.css app/stylesheets/_formtastic.scss`
`mv public/stylesheets/formtastic_changes.css app/stylesheets/_formtastic_changes.scss`

# capistrano
# TODO add a default deploy.rb
`bundle exec capify .`

# test harness
`bundle exec rails generate rspec:install`

if CONFIG[:features][:cucumber]
  `bundle exec rails generate cucumber:install --rspec --capybara`
end

# Done! Let's get this all under version control
`git init`
`git add .`
`git commit -am "Initial commit"`
