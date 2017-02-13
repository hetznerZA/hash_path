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

      it "returns nil for a top-level lookup failure" do
        expect(subject.object(dictionary, ["missing"])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.object(dictionary, [parent_x, "missing"])).to be_nil
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

      it "returns nil for a top-level lookup failure" do
        expect(subject.symbol(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.symbol(dictionary, %w[parent_x missing])).to be_nil
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

      it "returns nil for a top-level lookup failure" do
        expect(subject.string(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.string(dictionary, %w[parent_x missing])).to be_nil
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

      it "returns nil for a top-level lookup failure" do
        expect(subject.indifferent(dictionary, %w[missing])).to be_nil
      end

      it "returns nil for a nested lookup failure" do
        expect(subject.indifferent(dictionary, %w[parent_x missing])).to be_nil
      end
    end

  end

  describe ".[hash, path]" do

    it "is an alias for .indifferent(hash, path)"

  end

end
