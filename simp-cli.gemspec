$: << File.expand_path( '../lib/', __FILE__ )
require 'simp/cli/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'simp-cli'
  s.date     = Date.today.to_s
  s.summary  = 'a cli interface to configure/manage SIMP'
  s.description = <<-EOF
    simp-cli provides the 'simp' command to configure and manage SIMP.
  EOF
  s.version  = Simp::Cli::VERSION
  s.license  = 'Apache-2.0'
  s.email    = 'simp@simp-project.org'
  s.homepage = 'https://github.com/NationalSecurityAgency/rubygem-simp-cli'
  s.authors  = [
                 'Trevor Vaughan',
                 'Chris Tessmer',
                 'Kendall Moore',
                 'Nick Markowski',
                 'Adam Yohrling',
                 'Morgan Haskel',
               ]
  s.metadata = {
                 'issue_tracker' => 'https://github.com/simp/rubygem-simp-cli/issues'
               }

  s.executables = 'simp'

  # gem dependencies
  #   for the published gem
  s.add_runtime_dependency 'highline', '> 1.6.1', '< 1.8'

  #### NOTE: SIMP_RPM_BUILD
  ###
  ### In (RH)EL, RPMs for some vendor-provided ruby libraries are not
  ### distributed as rubygems, but insert themselves directly into the OS's
  ### ruby $LOAD_PATH.  The (autogenerated) binstub in EL will then fail if
  ### they were defined as dependencies in the original .gemspec (e.g., here).
  ###
  ### As a workaround for distributing this gems as an RPM:
  ###
  ### When the environment variable $SIMP_RPM_BUILD is set, the following
  ### dependencies will not be included in the .gemspec dependencies:
  #### ------------
  unless (
    ENV.fetch( 'SIMP_RPM_BUILD', false ) || \
    ENV.fetch( 'SIMP_CLI_GEMSPEC_NO_PUPPET_VERSION', false ) =~  /yes|true/
  )
    s.add_runtime_dependency 'puppet',   '>= 4.10', '< 7'
  end
  #### ------------

  # for development
  s.add_development_dependency 'rake',        '~> 10'
  s.add_development_dependency 'rspec',       '~> 3'
  s.add_development_dependency 'rspec-its',   '~> 1'
  s.add_development_dependency 'listen',      '~> 3.0.0'
  s.add_development_dependency 'guard',       '~> 2'
  s.add_development_dependency 'guard-shell', '~> 0'
  s.add_development_dependency 'guard-rspec', '~> 4'
  s.add_development_dependency 'pry',         '~> 0'
  s.add_development_dependency 'pry-doc',     '~> 0'
  s.add_development_dependency 'dotenv',      '~> 1'
  s.add_development_dependency 'rubocop',     '~> 0.29'

  # simple text description of external requirements (for humans to read)
  s.requirements << 'SIMP OS installation'

  # ensure the gem is built out of versioned files
  s.files = Dir['Rakefile', '{bin,lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z .`.split("\0")
end
