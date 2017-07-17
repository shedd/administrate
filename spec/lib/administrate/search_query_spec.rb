require "spec_helper"
require "administrate/search"

describe Administrate::Search::Query do
  let(:query) { "foo bar" }

  it "returns the parsed search terms" do
    query = described_class.new("foo bar")
    expect(query.terms).to eq("foo bar")
  end

  it "treats nil as a blank string" do
    query = described_class.new(nil)
    expect(query.terms).to eq("")
  end

  it "returns the original query" do
    query = described_class.new("original")
    expect(query.original).to eq("original")
  end

  it "uses the original query to represent itself as a string" do
    query = described_class.new("original")
    expect(query.to_s).to eq("original")
  end

  it "returns true if blank" do
    query = described_class.new("")
    expect(query).to be_blank
  end

  it "is not blank with only a filter" do
    query = described_class.new("foo:")
    expect(query).to_not be_blank
  end

  it "parses filter syntax" do
    query = described_class.new("vip: active:")
    expect(query.filters).to eq(["vip", "active"])
  end

  it "splits filters and terms" do
    query = described_class.new("vip: example.com")
    expect(query.filters).to eq(["vip"])
    expect(query.terms).to eq("example.com")
  end
end
