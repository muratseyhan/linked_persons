##
#
module LP
  class Container < RDF::LDP::Container
    include Encoding  
    include Persistable

    ##
    # Populates self with the elements identified by the given URI strings,
    # and saves self if not saved. 
    #
    # @param [Array<String>] arg - A URI string or a non-empty array 
    # of URI strings.
    #
    # @return self
    def fetch_for_uri_strs!(arg)
      fetch_for_uri_strs(arg)
      save unless saved?
      self
    end

    ##
    # Populates self with the elements identified by the given URI strings. 
    # 
    # @example
    #   container = LP::Container.new('http://example.org/my/container', \
    #     RDF::Repository.new)
    #   container.fetch_for_uri_strs(['http://viaf.org/viaf/36915259', \
    #     'http://viaf.org/viaf/27203135'])
    #
    # @param [Array<String>] arg - A URI string or a non-empty array 
    # of URI strings.
    #
    # @return self
    #
    # @raise [LP::Errors::BadParameters] If the provided arguments cannot be 
    # processed as an array of URIs.
    def fetch_for_uri_strs(arg)

      uri_strs = Array(arg)

      # Raise a proper error if did not get an array of strings.
      unless uri_strs.size > 0 && uri_strs.all? { |uri_str| uri_str.is_a? String }
        raise Errors::BadParameters 
      end

      uri_strs.map do |uri_str|
        person_uri_str = "?uri=#{encode(uri_str)}"
        person = Person.new(person_uri_str, @data)
        person.fetch_for_uri_str!(uri_str)
        
      end.each do |person|
        add_element person
      end

      self
      
    end

    ##
    # Add an element to the container
    #
    # @param [RDF::LDP::RDFSource] element
    # @return self
    #
    def add_element(element)
      graph << element.graph 
      add(element)
      self
    end

  end # LP::Container
end