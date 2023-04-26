module OpenaiHelper
  CLIENT = OpenAI::Client.new

  def self.get_embeddings(input)
    response = CLIENT.embeddings(parameters: {
      model: "text-search-curie-doc-001",
      input: input
    })

    JSON.parse(response.body)['data'][0]['embedding']
  end
end