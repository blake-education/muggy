module Muggy
  module Support
    module Memoisation
      class << self
        def included(base)
          base.extend ClassMethods
          base.extend Methods
          base.send :include, Methods
        end

        KeyPrefix = "__muggy_memo_".freeze

        module ClassMethods
          def memoised(name)
            class_eval <<-EOEVAL
              def #{name}
                Thread.current[:#{memo_key(name)}] = #{name}!
              end
            EOEVAL
          end
        end

        module Methods
          def memo_key(key)
            "#{KeyPrefix}#{key}"
          end

          def clear_memoised_value!(key)
            Thread.current[memo_key(key)] = nil
          end

          def set_memoised_value!(key,value)
            Thread.current[memo_key(key)] = value
          end
        end
      end
    end
  end
end
