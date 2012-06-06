class SpecFinder
  class << self
    def test_files
      Dir['spec/**/*_spec.rb']
    end

    def integration_test_files
      Dir['spec/integration/**/*.rb']
    end

    def unit_test_files
      test_files - integration_test_files
    end
  end
end
