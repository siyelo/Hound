class SpecFinder
  class << self
    def test_files
      Dir['spec/**/*_spec.rb']
    end

    def integration_test_files
      Dir['spec/**/*_integration_spec.rb']
    end

    def acceptance_test_files
      Dir['spec/**/*_acceptance_spec.rb'] + Dir['spec/**/*_functional_spec.rb']
    end

    def unit_test_files
      self.test_files - self.integration_test_files - self.acceptance_test_files
    end
  end
end
