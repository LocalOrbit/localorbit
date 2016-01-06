//= require reflux.min
//= require jquery

(function() {

  var DashboardActions = Reflux.createActions([
    "setBaseUrl",
    "loadDashboard",
    "newIntervalQuery",
    "newEntityQuery",
    "updateDashboard"
  ]);

  var DashboardStore = Reflux.createStore({
    init: function() {
      this.dashboard = {};
        this.interval = "1";
        this.selectedEntity = "B";
      this.url = window.location.protocol + "//" + window.location.host + "/api/v1/dashboards";
      this.parameters = {
        dateRange: "1",
        viewAs: "B"
      };
      this.loading = false;
      this.listenTo(DashboardActions.loadDashboard, this.loadDashboard);
      this.listenTo(DashboardActions.newIntervalQuery, this.newIntervalQuery);
      this.listenTo(DashboardActions.newEntityQuery, this.newEntityQuery);
      this.listenTo(DashboardActions.updateDashboard, this.updateDashboard);
    },

    newIntervalQuery: function(query) {
      this.parameters.dateRange = query;
      this.parameters.viewAs = this.selectedEntity;
      DashboardActions.loadDashboard();
    },

    newEntityQuery: function(view_as) {
      this.parameters.dateRange = this.interval;
      this.parameters.viewAs = view_as;
      DashboardActions.loadDashboard();
    },

    loadDashboard: function() {
      this.loading = true;
      $.getJSON(this.url, this.parameters, this.onLoad, this.onLoadError);
    },

    onLoad: function(res) {
        this.dashboard = res;
        this.trigger(this.dashboard);
        this.loading = false;
    },

    updateDashboard: function() {
      this.trigger(this.dashboard);
    },

    onLoadError: function(err) {
      console.error('Error loading dashboard', err);
      this.loading = false;
    }
  });

  window.lo = window.lo || {};
  _.extend(window.lo, {
    DashboardStore: DashboardStore,
    DashboardActions: DashboardActions
  });
}).call(this);
