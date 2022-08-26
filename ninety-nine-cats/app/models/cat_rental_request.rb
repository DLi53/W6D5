# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :bigint           not null, primary key
#  cat_id     :bigint           not null
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           default("PENDING"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CatRentalRequest < ApplicationRecord
    validates :status, inclusion: ['PENDING', 'APPROVED', 'DENIED']
    validates_presence_of :cat_id, :start_date, :end_date, :status
    validate :does_not_overlap_approved_request

    belongs_to :cat

    def overlapping_requests
        CatRentalRequest.where(cat_id: self.cat_id)
            .where.not(id: self.id)
            .where('(start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)', self.start_date, self.end_date, self.start_date, self.end_date)
    end

    def overlapping_approved_requests
        self.overlapping_requests.select {|request| request.status == 'APPROVED'}
    end

    def does_not_overlap_approved_request
        if !self.overlapping_approved_requests.empty? # if there ARE overlapping approved requests
            errors.add(:request_dates, "can't overlap with existing approved requests")
        end
    end
end
