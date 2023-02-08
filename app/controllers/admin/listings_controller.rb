require 'csv'

class Admin::ListingsController < Admin::AdminBaseController
  before_action :set_listing, except: :index

  def index
    @selected_left_navi_link = "listings"
    @listings = if params[:query].present?
      Listing.currently_open.where("lower(title) LIKE ?", "%#{params[:query].downcase}%").references(:listing).paginate(page: params[:page]).order('id DESC')
    else
      Listing.paginate(page: params[:page]).order('id DESC')
    end

    respond_to do |format|
      format.html
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end
        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-listings-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          generate_csv_for(yielder, @listings, @current_community)
        end
      end
    end
  end

  def destroy
    @listing.update_attribute(:deleted, true)
    @listing.update_column(:delete_note, params[:delete_note]) if params[:delete_note].present?
    flash[:notice] = "Listing with title '#{@listing.title}' has been deleted."
    redirect_to admin_community_listings_path(@current_community)
  end

  def add
    @listing.update_attribute(:deleted, false)
    flash[:notice] = "Listing with title '#{@listing.title}' has been added again."
    redirect_to admin_community_listings_path(@current_community)
  end

  private
    def set_listing
      @listing ||= Listing.find(params[:id])
    end

    def generate_csv_for(yielder, listings, community)
      # first line is column names
      header_row = %w{
        Id
        Title
        Seller
        date_listed
        status
        deleted?
      }
      header_row.push("can_post_listings") if community.require_verification_to_post_listings
      yielder << header_row.to_csv(force_quotes: true)
      listings.find_each do |listing|
        yielder << [
          listing.id,
          listing.title,
          listing.author.name_or_username,
          listing.created_at.strftime("%b %d, %Y"),
          listing.current_state,
          listing.deleted ? 'yes' : 'no'
        ].to_csv(force_quotes: true)
      end
    end
end
