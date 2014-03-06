shared_examples "a soft deleted model" do
  it "has a visible scope" do
    expect(subject.class).to respond_to(:visible)
  end

  it "has a deleted_at attribute" do
    expect(subject).to respond_to(:deleted_at)
  end

  it "is not visible" do
    expect(subject.class.visible).to include(subject)
    subject.class.soft_delete(subject.id)
    expect(subject.class.visible).to_not include(subject)
  end
end
