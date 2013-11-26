module CustomReport
  class Settings < Hash
    def method_missing(name, *args)
      return self[name] if args.length == 0
      self[name] = args.first if args.length == 1
      super
    end
  end
end
