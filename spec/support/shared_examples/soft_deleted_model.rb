shared_examples "a soft deleted model" do
  it "is not visible" do
    expect(subject.class.visible).to include(subject)
    subject.class.soft_delete(subject.id)
    expect(subject.class.visible).to_not include(subject)
  end
end
