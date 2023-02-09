Given "an online store is configured" do
  configuration = File.open(Rails.root.join("features", "support", "store_configuration.yml")) { |f| f.read }
  @account = Account.where(name: "Online Store").first_or_create(configuration: configuration)
end
