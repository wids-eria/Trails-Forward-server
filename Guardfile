group :dev do
  guard 'bundler' do
    watch('Gemfile')
    # Uncomment next line if Gemfile contain `gemspec' command
    # watch(/^.+\.gemspec/)
  end

  guard 'migrate' do
    watch(%r{^db/migrate/(\d+).+\.rb})
  end

  guard 'rails' do
    watch('Gemfile.lock')
    watch('db/schema')
    watch(%r{^(config|lib)/.*})
  end
end

group :test do
  guard 'rspec', :version => 2 do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb",
      "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
      "spec/acceptance/#{m[1]}_spec.rb"] }
      watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
      watch('spec/spec_helper.rb')                        { "spec" }
      watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  end

  guard 'cucumber' do
    watch(%r{^features/.+\.feature$})
    watch(%r{^features/support/.+$})          { 'features' }
    watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
  end
end
