require "spec_helper"
require_relative "../lib/active_record_sql_unionizer.rb"

describe "ActiveRecordSqlUnionizer" do
  class Dummy < ActiveRecord::Base
    include ActiveRecordSqlUnionizer
  end

  it "returns ActiveRecord relation that is union of relations and SQL queries" do
    dummy_1 = Dummy.create!
    dummy_2 = Dummy.create!(name: "second")
    Dummy.create!(name: "not me")
    sql_string = "SELECT * FROM dummies WHERE name='second'"
    active_record_relation = Dummy.where(id: dummy_1.id)


    result = Dummy.unionize(sql_string, active_record_relation)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "works with inherited classes" do
    class ChildDummy < Dummy
      include ActiveRecordSqlUnionizer
    end

    dummy_1 = ChildDummy.create!
    dummy_2 = ChildDummy.create!(name: "second")
    ChildDummy.create!(name: "not me")
    sql_string = "SELECT * FROM dummies WHERE name='second' AND type='ChildDummy'"
    active_record_relation = ChildDummy.where(id: dummy_1.id)


    result = ChildDummy.unionize(sql_string, active_record_relation)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "can take a class method as an argument" do
    dummy_1 = Dummy.create!
    dummy_2 = Dummy.create!(name: "second")
    Dummy.create!(name: "not me")
    Dummy.singleton_class.class_eval do
      define_method(:some_scoping_method) do
        where(id: dummy_1.id)
      end
    end
    sql_string = "SELECT * FROM dummies WHERE name='second'"


    result = Dummy.unionize(sql_string, :some_scoping_method)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "raises when symbol passed in is not a class method" do
    Dummy.create!(name: "second")
    sql_string = "SELECT * FROM dummies WHERE name='second'"


    expect {Dummy.unionize(sql_string, :not_defined_class_method)}.to raise_error(
        "ActiveRecordSqlUnionizer expected Dummy to respond to not_defined_class_method, but it does not"
    )
  end
end
