require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:academic_status_id) }
end
