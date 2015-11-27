class Unresponsys
  class Row
    def initialize(table, fields)
      @table  = table
      @fields = fields

      @fields.each_pair do |key, val|
        str = key.downcase.chomp('_')
        var = "@#{str}".to_sym
        val = val.to_responsys
        self.instance_variable_set(var, val)

        if key == 'ID_'
          self.class.send(:attr_reader, str)
        else
          self.class.send(:attr_accessor, str)
        end
      end
    end

    def save
      record_data = { fieldNames: [], records: [[]], mapTemplateName: nil }
      @fields.each_pair do |key, val|
        record_data[:fieldNames] << key
        var = "@#{key.downcase.chomp('_')}".to_sym
        val = self.instance_variable_get(var)
        val = val.to_responsys
        record_data[:records][0] << val
      end

      options = { body: { recordData: record_data, insertOnNoMatch: true, updateOnMatch: 'REPLACE_ALL' } }
      r = Unresponsys::Client.post("/folders/#{@table.folder.name}/suppData/#{@table.name}/members", options)
      r['recordData']['records'][0][0].include?('MERGEFAILED')
    end

    def delete
      options = { query: { qa: 'ID_', id: @fields.primary_key } }
      r = Unresponsys::Client.delete("/folders/#{@table.folder.name}/suppData/#{@table.name}/members", options)
      r['recordData']['records'][0][0].include?('DELETEFAILED')
    end

    # allow to access custom fields on new record
    def method_missing(sym, *args, &block)
      setter  = sym.to_s.include?('=')
      str     = sym.to_s.chomp('=')
      var     = "@#{str}".to_sym
      val     = args.first

      if setter
        field_name = str.upcase
        @fields[field_name] = ''
        self.instance_variable_set(var, val)
      else
        self.instance_variable_get(var)
      end
    end
  end
end
