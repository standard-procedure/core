Then("the {string} should have a {int} hour deadline set against it") do |item_type, int|
  @deadline = @item.deadlines.active.find_by(hours: int)
  expect(@deadline).to_not be_nil
end

When("the {int} hour delivery deadline has passed") do |int|
  # do nothing
end

Then("the {string} should have a status of {string}") do |item_type, status|
  expect(@item.status).to eq status
end

Then("the previous deadline should be cancelled") do
  @deadline.reload
  expect(@deadline).to be_cancelled
end
