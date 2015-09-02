//= require reflux.min
//= require jquery

(function() {
  var FilterActions = Reflux.createActions([
    "loadInitialFilters",
    "loadChildFilters",
  ]);

  var FilterStore = Reflux.createStore({
    init: function() {
      this.filters = {
        topLevel: [],
        children: []
      };
      this.cachedChildren = {};

      this.url = window.location.protocol + "//" + window.location.host + "/api/v1/filters";
      this.listenTo(FilterActions.loadInitialFilters, this.loadInitialFilters);
      this.listenTo(FilterActions.loadChildFilters, this.loadChildFilters);
    },

    loadInitialFilters: function() {
      $.getJSON(this.url, {}, this.onLoadInitialFilters, this.onLoadError);
    },

    loadChildFilters: function(id) {
      if(this.cachedChildren[id]) {
        this.onLoadChildFilters(this.cachedChildren[id]);
      }
      else {
        $.getJSON(this.url, {parent_id: id}, function(res) {
          this.cachedChildren[id] = res.filters;
          this.onLoadChildFilters(res.filters);
        }.bind(this), this.onLoadError);
      }
    },

    onLoadChildFilters: function(childFilters) {
      this.filters.children = childFilters;
      this.trigger(this.filters);
    },

    onLoadInitialFilters: function(res) {
      this.filters.topLevel = [{name: "Suppliers", id: "suppliers"}].concat(res.filters);
      this.trigger(this.filters);
    },

    onLoadError: function(err) {
      console.error('Error loading filters', err);
    }
  });

  window.lo = window.lo || {};
  _.extend(window.lo, {
    FilterStore: FilterStore,
    FilterActions: FilterActions
  });
}).call(this);