module OpenaiHelper
  CLIENT = OpenAI::Client.new

  def self.get_embeddings(input)
    response = CLIENT.embeddings(parameters: {
      model: "text-search-curie-doc-001",
      input: input
    })

    JSON.parse(response.body)['data'][0]['embedding']
  end

  def self.get_completions(prompt)
    response = CLIENT.completions(
      parameters: {
        # We use temperature of 0.0 because it gives the most predictable, factual answer.
        "temperature": 0.0,
        "max_tokens": 150,
        "model": "text-davinci-003",
        "prompt": prompt,
      })
    
    res = JSON.parse(response.body)["choices"][0]["text"]

    res
  end
end