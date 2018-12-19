require 'rspec'
require_relative 'file_scanner'

RSpec.describe FileScanner do
	it "Runs very well" do
    dirname = '/Users/shaul/Documents/dev/exercises'

    statement = double("statement", execute:'Done')
    mysql = double("mysql", prepare:statement)
    allow(mysql).to receive(:last_id).and_return(1, 2, 3)

    expect(mysql).to receive(:prepare).with(String).twice
    expect(mysql).to receive(:last_id).once
    expect(statement).to receive(:execute).with(dirname, 2140).once

    FileScanner.new(mysql).run dirname
  end
end