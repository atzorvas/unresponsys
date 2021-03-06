require 'spec_helper'

describe Unresponsys::SupplementalTable do

  before :each do
    @client = Unresponsys::Client.new(username: ENV['R_USER'], password: ENV['R_PASS'])
    allow(@client).to receive(:authenticate).and_return(true)

    folder  = @client.folders.find('TestData')
    @table  = folder.supplemental_tables.find('TestTable')
  end

  it '#rows.find returns an instance of Row when a row exists' do
    VCR.use_cassette('find_row_exists') do
      row = @table.rows.find(1)
      expect(row).to be_an_instance_of(Unresponsys::Row)
    end
  end

  it '#rows.find raises an error when a row does not exist' do
    VCR.use_cassette('find_row_doesnt_exist') do
      expect {
        @table.rows.find(2)
      }.to raise_error(Unresponsys::NotFound)
    end
  end

  it '#rows.new returns an instance of Row' do
    row = @table.rows.new('ID_' => 2)
    expect(row).to be_an_instance_of(Unresponsys::Row)
  end

end
