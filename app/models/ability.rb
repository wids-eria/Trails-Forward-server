class Ability
  include CanCan::Ability

  def initialize(user)

    can :index_worlds, World do
      true
    end

    can :show_world, World do
      true
    end

    can :access_private_data, Player, :user_id => user.id
    can :access_private_data, User, :id => user.id

    can :create_player, User, :id => user.id
    can :update_player, Player, :user_id => user.id

    can :index_user_players, :all
    can :show_player, :all

    # users can only do things in worlds they inhabit
    can :do_things, World do |world|
      world.player_for_user(user)
    end

    can :index_listings, World do |world|
      can? :do_things, world
    end

    can :list_megatiles_for_sale, World do |world|
      can? :do_things, world
    end

    can :list_for_sale, Megatile do |megatile|
      megatile.world.player_for_user(user) == megatile.owner
    end

    can :bid, Megatile do |megatile|
      # the user doesn't already own the tile
      (can? :do_things, megatile.world) and ( megatile.owner != megatile.world.player_for_user(user) )
    end

    can :see_bids, Megatile do |megatile|
      (megatile.world.player_for_user(user) == megatile.owner) or (megatile.owner == nil)
    end

    can :see_bids, Player, :user_id => user.id

    can :accept_bid, Bid do |bid|
      # assumes that all requested land in the bid has the same owner
      megatiles = bid.requested_land.megatiles
      megatile = megatiles.first
      megatile.world.player_for_user(user) == megatile.owner
    end

    can :bulldoze, ResourceTile do |rt|
      rt.megatile.world.player_for_user(user) == rt.megatile.owner
    end

    can :clearcut, ResourceTile do |rt|
      player = rt.megatile.world.player_for_user(user)
      player && player == rt.megatile.owner
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
