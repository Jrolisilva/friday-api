Rails.application.routes.draw do
  post '/payments', to: 'payments#create'
  get '/payments-summary', to: 'payments_summary#show'

  # sanity check
  get "/" => proc { [200, { "Content-Type" => "application/json" }, [{ status: "ok" }.to_json]] }
end
