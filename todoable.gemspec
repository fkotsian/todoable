Gem::Specification.new do |s|
  s.name = "Todoable"
  s.authors = ['Frank Kotsianas']
  s.version = "0.0.1"
  s.date = %q{2019-06-21}
  s.summary = %q{Get and fetch all your todos with our handy gem!}
  s.files = [
    'lib/todoable.rb',
  ]
  s.require_paths = ['lib']
  s.add_runtime_dependency 'http', '~> 4.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
