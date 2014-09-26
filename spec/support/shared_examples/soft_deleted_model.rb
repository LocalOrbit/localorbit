shared_context "soft delete-able models" do
  let(:model_sym) { described_class.name.underscore.to_sym }
  let!(:models) { described_class.delete_all
                  [create(model_sym),
                   create(model_sym),
                   create(model_sym)] }
  subject { models[0] }
end

shared_examples "a soft deleted model" do
  it "which .visible scope includes only the models that haven't been soft-deleted" do
    # Sanity check db count of models:
    expect(described_class.visible.count).to eq(models.count)

    # Soft delete the second model:
    models[1].soft_delete
    # See the visible count drop by 1:
    expect(described_class.visible.count).to eq(models.count-1)
    # See the all count stays where it was:
    expect(described_class.all.count).to eq(models.count)

    # See which specific models are visible:
    expect(described_class.visible.map(&:id)).to contain_exactly(models[0].id ,models[2].id)

    # Prove the soft-deleted model still exists
    expect(described_class.find(models[1].id)).to eq(models[1])
  end

  it "which marks a model with deleted_at" do
    expect(subject.deleted_at).to be_nil
    subject.soft_delete
    expect(subject.deleted_at).to be_about(Time.current)
  end

  it "which provides class-level soft-deletion by id" do
    expect(described_class.visible).to include(subject)
    described_class.soft_delete(subject.id)
    expect(described_class.visible).to_not include(subject)
  end

  it "which may be undeleted" do
    subject.soft_delete
    expect(described_class.visible).to_not include(subject)
    expect(subject.deleted_at).to be_about(Time.current)

    subject.undelete
    expect(described_class.visible).to include(subject)
    expect(subject.deleted_at).to be_nil
  end

  it "which can be scope-wise mass-deleted" do
    # Soft delete the first and last models by 'where' scope:
    described_class.where(id: [models[0], models[2]].map(&:id)).soft_delete_all
    # See only the middle model remains visible:
    expect(described_class.visible).to eq([models[1]])

    # See all models actually live in db:
    expect(described_class.all).to include(models[0])
    expect(described_class.all).to include(models[1])
    expect(described_class.all).to include(models[2])

  end
end
