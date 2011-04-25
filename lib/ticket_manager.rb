module TicketManager 
  def self.included(base) 
    base.send(:extend, TicketManagerClass )
  end

  module TicketManagerClass
    def next_to(place)

      place= place.id if place.is_a? Place

      next_ticket = Ticket.where(:place_id => place, 
                                 :ticket_type_id => TicketType.preferencial.id, 
                                 :status_ticket_id => StatusTicket.available.id, 
                                 :created_at => Date.today.midnight...Date.tomorrow.midnight).order(:created_at).first


      next_ticket ||= Ticket.where(:place_id => place, 
                                   :status_ticket_id => StatusTicket.available.id, 
                                   :created_at => Date.today.midnight...Date.tomorrow.midnight).order(:created_at).first

      next_ticket
    end
  end
end