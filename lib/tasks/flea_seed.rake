namespace :db do
	namespace :seed do
		Dir[File.join(Rails.root, 'db/seed_helpers', '*.rb')].each do |filename|
			task_name = File.basename(filename, '.rb').intern
			task task_name => :environment do
        load(filename) if File.exist?(filename)
        if self.respond_to?(task_name, :include_private)
          self.send(task_name)
        else
          puts "Make sure your method is called #{task_name} inside of db/seed_helpers/#{task_name}.rb"
        end
			end
		end
	end
end