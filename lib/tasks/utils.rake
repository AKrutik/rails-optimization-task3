# frozen_string_literal: true

# rake reload_json[fixtures/large.json]
task :reload_json, [:file_name] => :environment do |_task, args|
  ImportData.run!(file_name: args.file_name)
end
