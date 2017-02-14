require "spec_helper"

require "hash_pick"

describe HashPick do

  subject { described_class }

  describe ".object(hash, path)" do

    context "with an object-keyed dictionary" do

      let(:parent_x) { Object.new }
      let(:parent_y) { Object.new }
      let(:child_x)  { Object.new }
      let(:child_y)  { Object.new }
      let(:dictionary) do
        {
          parent_x => {
            child_x => "parent_x-child_x",
            child_y => "parent_x-child_y",
          },
          parent_y => {
            child_x => "parent_y-child_x",
            child_y => "parent_y-child_y",
          }
        }
      end

      it "returns top-level lookup" do
        expect(subject.object(dictionary, [parent_x])).to eql(dictionary[parent_x])
      end

      it "supports nested lookup" do
        expect(subject.object(dictionary, [parent_x, child_y])).to eql(dictionary[parent_x][child_y])
      end

      it "returns the dictionary itself for an empty path" do
        expect(subject.object(dictionary, [])).to eql(dictionary)
      end

      it "returns nil for a top-level lookup failure" do
        expect(subject.object(dictionary, ["missing"])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.object(dictionary, [parent_x, "missing"])).to be_nil
      end

      it "supports nil as a key" do
        dictionary = {parent_x => {nil => {child_x => "parent_x-nil-child_x"}}}
        expect(subject.object(dictionary, [parent_x, nil, child_x])).to eql(dictionary[parent_x][nil][child_x])
      end
    end

  end

  describe ".symbol(hash, path)" do

    context "with a symbol-keyed dictionary" do
      let(:dictionary) do
        {
          parent_x: {
            child_x: "parent_x-child_x",
            child_y: "parent_x-child_y",
          },
          parent_y: {
            child_x: "parent_y-child_x",
            child_y: "parent_y-child_y",
          }
        }
      end

      it "returns top-level lookup" do
        expect(subject.symbol(dictionary, %w[parent_x])).to eql(dictionary[:parent_x])
      end

      it "supports nested lookup" do
        expect(subject.symbol(dictionary, %w[parent_x child_y])).to eql(dictionary[:parent_x][:child_y])
      end

      it "returns the dictionary itself for an empty path" do
        expect(subject.symbol(dictionary, [])).to eql(dictionary)
      end

      it "returns nil for a top-level lookup failure" do
        expect(subject.symbol(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.symbol(dictionary, %w[parent_x missing])).to be_nil
      end

      it "does not support nil as a key (raises error)" do
        dictionary = {parent_x: {nil => {child_x: "parent_x-nil-child_x"}}}
        expect { subject.symbol(dictionary, [:parent_x, nil, :child_x]) }.to raise_error(ArgumentError, /nil.*path/)
      end
    end

  end

  describe ".string(hash, path)" do

    context "with a string-keyed dictionary" do
      let(:dictionary) do
        {
          "parent_x" => {
            "child_x" => "parent_x-child_x",
            "child_y" => "parent_x-child_y",
          },
          "parent_y" => {
            "child_x" => "parent_y-child_x",
            "child_y" => "parent_y-child_y",
          }
        }
      end

      it "returns top-level lookup" do
        expect(subject.string(dictionary, %w[parent_x])).to eql(dictionary["parent_x"])
      end

      it "supports nested lookup" do
        expect(subject.string(dictionary, %w[parent_x child_y])).to eql(dictionary["parent_x"]["child_y"])
      end

      it "returns the dictionary itself for an empty path" do
        expect(subject.string(dictionary, [])).to eql(dictionary)
      end

      it "returns nil for a top-level lookup failure" do
        expect(subject.string(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.string(dictionary, %w[parent_x missing])).to be_nil
      end

      it "does not support nil as a key (raises error)" do
        dictionary = {"parent_x" => {nil => {"child_x" => "parent_x-nil-child_x"}}}
        expect { subject.string(dictionary, ["parent_x", nil, "child_x"]) }.to raise_error(ArgumentError, /nil.*path/)
      end
    end

  end

  describe ".indifferent(hash, path)" do

    context "with a mixed symbol-and-string-keyed dictionary" do
      let(:dictionary) do
        {
          parent_x: {
            "child_x" => "parent_x-child_x",
            "child_y" => "parent_x-child_y",
          },
          parent_y: {
            "child_x" => "parent_y-child_x",
            "child_y" => "parent_y-child_y",
          }
        }
      end

      it "returns top-level lookup" do
        expect(subject.indifferent(dictionary, %w[parent_x])).to eql(dictionary[:parent_x])
      end

      it "supports nested lookup" do
        expect(subject.indifferent(dictionary, %w[parent_x child_y])).to eql(dictionary[:parent_x]["child_y"])
      end

      it "returns the dictionary itself for an empty path" do
        expect(subject.indifferent(dictionary, [])).to eql(dictionary)
      end

      it "returns nil for a top-level lookup failure" do
        expect(subject.indifferent(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.indifferent(dictionary, %w[parent_x missing])).to be_nil
      end

      it "does not support nil as a key (raises error)" do
        dictionary = {parent_x: {nil => {"child_x" => "parent_x-nil-child_x"}}}
        expect { subject.indifferent(dictionary, ["parent_x", nil, "child_x"]) }.to raise_error(ArgumentError, /nil.*path/)
      end
    end

  end

  describe ".pick(hash, path)" do

    it "iterates the path over the hash" do
      dictionary = {foo: {bar: "payload"}}
      block_received = []
      subject.pick(dictionary, [:foo, :bar]) { |p, k| block_received << [p, k]; p[k] }
      expect(block_received).to eql([
        [dictionary, :foo],
        [dictionary[:foo], :bar]
      ])
    end

  end

  describe ".[hash, path]" do

    it "is an alias for .indifferent(hash, path)"

  end

end
