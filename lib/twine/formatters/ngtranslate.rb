module Twine
  module Formatters
    class NgTranslate < JQuery
      FORMAT_NAME = 'ngtranslate'
      EXTENSION = '.json'
      DEFAULT_FILE_NAME = 'localize.json'

      def write_file(path, lang)
        begin
          require "json"
        rescue LoadError
          raise Twine::Error.new "You must run 'gem install json' in order to read or write jquery-localize files."
        end

        default_lang = @strings.language_codes[0]
        encoding = @options[:output_encoding] || 'UTF-8'
        File.open(path, "w:#{encoding}") do |f|
          f.puts "{"

          @strings.sections.each_with_index do |section, si|
            section.rows.each_with_index do |row, ri|
              if row.matches_tags?(@options[:tags], @options[:untagged])
                key = row.key
                key = key.gsub('"', '\\\\"')
                key = key.split[0]

                value = row.translated_string_for_lang(lang, default_lang)
                value = value.gsub('"', '\\\\"')


                # process the %(token)s
                value = value.gsub(/%\((([a-zA-Z]|\d|\s|-|_|\.)+)\)s/, '{{\1}}')

                # process the %@ and %d
                value = value.gsub("%d", "%@")
                token_index = 0
                while value.include? "%@" do
                  value = value.sub("%@", "{{s#{token_index}}}")
                  token_index += 1
                end

                f.print "\"#{key}\":\"#{value}\","
                f.print "\n"
              end
            end
          end
          f.seek(-2, IO::SEEK_CUR)
          f.puts "\n}"

        end
      end
    end
  end
end
