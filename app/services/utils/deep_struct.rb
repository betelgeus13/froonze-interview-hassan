module Utils
  class DeepStruct
    def call(object:)
      { result: recursive_deep_struct(object: object) }
    end

    private

    def recursive_deep_struct(object:)
      if object.is_a?(Hash)
        OpenStruct.new(
          object.each_with_object({}) do |(k, v), obj|
            obj[k] = recursive_deep_struct(object: v)
          end
        )
      elsif object.is_a?(Array)
        object.map { |e| recursive_deep_struct(object: e) }
      else
        object
      end
    end
  end
end
