# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'

describe Pipely::Bundler::ProjectGem do

  let(:project_spec) do
    double "Gem::Specification",
      name: "my-project",
      file_name: "/path/to/cache/my-project.gem"
  end

  subject { described_class.new(project_spec) }

  describe ".load" do
    let(:filename) { 'foo.gemspec' }
    let(:gemspec) { double }

    before do
      allow(Dir).to receive(:glob).with("*.gemspec") { [ filename ] }
      allow(Gem::Specification).to receive(:load).with(filename) { gemspec }
    end

    it "loads the gemspec" do
      loaded = described_class.load
      expect(loaded.project_spec).to eq(gemspec)
    end
  end

  describe "#gem_files" do
    let(:dependency_gem_files) do
      {
        'packaged-gem1' => '/path/to/cache/packaged-gem1.gem',
        'built-from-source-gem1' => '/path/to/cache/built-from-source-gem1.gem',
      }
    end

    let(:project_gem_file) do
      {
        project_spec.name => project_spec.file_name
      }
    end

    before do
      allow(subject).to receive(:dependency_gem_files) { dependency_gem_files }
      allow(subject).to receive(:project_gem_file) { project_gem_file }
    end

    it "combines the dependency_gem_files and the project_gem_file" do
      expect(subject.gem_files.keys).to match_array(
        dependency_gem_files.keys + project_gem_file.keys
      )
    end

    it "lists the project_gem_file last" do
      expect(subject.gem_files.keys.last).to eq(project_spec.name)
    end
  end

  describe "#dependency_gem_files" do
    let(:bundle_gem_files) do
      {
        'packaged-gem1' => '/path/to/cache/packaged-gem1.gem',
        'built-from-source-gem1' => '/path/to/cache/built-from-source-gem1.gem',
        'bundler' => '/path/to/cache/bundler.gem',
        project_spec.name => project_spec.file_name,
      }
    end

    let(:bundle) do
      double "Pipely::Bundler::Bundle", gem_files: bundle_gem_files
    end

    it "should filter out the bundler gem and the project gem" do
      result = subject.dependency_gem_files(bundle)
      expect(result.keys).to eq(%w[ packaged-gem1 built-from-source-gem1 ])
    end
  end

  describe "#project_gem_file" do
    let(:gem_packager) { double "Pipely::Bundler::GemPackager" }
    let(:project_gem_file) { double }

    before do
      allow(gem_packager).to receive(:build_from_source) { project_gem_file }
    end

    it "should return the project's own gem file" do
      result = subject.project_gem_file(gem_packager)
      expect(result).to eq(project_gem_file)
    end
  end

end