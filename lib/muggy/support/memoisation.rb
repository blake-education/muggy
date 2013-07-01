module Muggy
  module Support
    module Memoisation
      class << self
        def included(base)
          base.extend ClassMethods
          base.extend Methods
          base.include Methods
        end

        KeyPrefix = "__muggy_memo_".freeze

        module ClassMethods
          def memoised(name)
            class_eval <<-EOEVAL
              def #{name}
                Thread.current[:#{memo_key(key)}] ||= #{name}!
              end
            EOEVAL
          end
        end

        module Methods
          def memo_key(key)
            "#{KeyPrefix}#{key}"
          end

          def delete_memoised_value!(key)
            Thread.current.delete(memo_key(key))
          end

          def set_memoised_value!(key,value)
            Thread.current[memo_key(key)] = value
          end
        end
      end
    end
  end
end
