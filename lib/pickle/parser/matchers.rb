module Pickle
  class Parser
    module Matchers
	
			@@year_pat = '(?:(?:19|20)\d\d)'
			@@day_pat = '(?:(?:3[0-1])|(?:2\d)|(?:1\d)|(?:0?[1-9]))'
			@@abbr_month_names = Date::ABBR_MONTHNAMES.slice(1..12).join('|')
			@@month_pat = '(?:(?:1[012])|(?:0?[1-9]))'
	
      def match_ordinal
        '(?:\d+(?:st|nd|rd|th))'
      end
  
      def match_index
        "(?:first|last|#{match_ordinal})"
      end
  
      def match_prefix
        '(?:(?:a|an|another|the|that) )'
      end
  
			def match_year
				@@year_pat
			end
	
			def match_month_num
				@@month_pat
			end

			def match_day
				@@day_pat
			end
			
			def _match_date1
				"(?:#{match_year}[-\/]#{match_month_num}[-\/]#{match_day})"
			end
			
			def _match_date2
				"(?:#{match_day}[-\/]#{match_month_num}[-\/]#{match_year})"
			end
			
			def _match_date3
				"(?:(?:#{@@abbr_month_names})\s+#{match_day},?\s*#{match_year})"
			end
	
		
 			def match_date
				"(?:#{_match_date1}|#{_match_date2}|#{_match_date3})"
			end

			def match_quoted
		     '(?:\\\\"|[^\\"]|\\.)*'
			end

      def match_label
        "(?::? \"#{match_quoted}\")"
      end

			def match_number
				'\d+'
			end

      def match_value
        "(?:\"#{match_quoted}\"|#{match_date}|nil|true|false|[+-]?[0-9_]+(?:\\.\\d+)?)"
        # "(?:\"#{match_quoted}\"|nil|true|false|[+-]?[0-9]+(?:\\.\\d+)?)"
      end

      def match_field
        "(?:\\w+: #{match_value})"
      end
  
      def match_fields
        "(?:#{match_field}, )*#{match_field}"
      end
  
      def match_mapping
        "(?:#{config.mappings.map(&:search).join('|')})"
      end
  
      def match_factory
        "(?:#{config.factories.keys.map{|n| n.gsub('_','[_ ]')}.join('|')})"
      end
      
      def match_plural_factory
        "(?:#{config.factories.keys.map{|n| n.pluralize.gsub('_','[_ ]')}.join('|')})"
      end
      
      def match_indexed_model
        "(?:(?:#{match_index} )?#{match_factory})"
      end
  
      def match_labeled_model
        "(?:#{match_factory}#{match_label})"
      end
  
      def match_model
        "(?:#{match_mapping}|#{match_prefix}?(?:#{match_indexed_model}|#{match_labeled_model}))"
      end
  
      def match_predicate
        "(?:#{config.predicates.map{|m| m.to_s.sub(/^has_/,'').sub(/\?$/,'').gsub('_','[_ ]')}.join('|')})"
      end
      
      # create capture analogues of match methods
      instance_methods.select{|m| m =~ /^match_/}.each do |method|
        eval <<-end_eval                   
          def #{method.to_s.sub('match_', 'capture_')}         # def capture_field
            "(" + #{method} + ")"                         #   "(" + match_field + ")"
          end                                             # end
        end_eval
      end
  
      # special capture methods
      def capture_number_in_ordinal
        '(?:(\d+)(?:st|nd|rd|th))'
      end
  
      def capture_name_in_label
        "(?::? \"(#{match_quoted})\")"
      end
  
      def match_key_and_value_in_field
        "(?:\\w+: #{match_value})"
      end

      def capture_key_and_value_in_field
        "(?:(\\w+): (#{match_value}))"
      end
    end
  end
end