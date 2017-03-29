(function () {
    'use strict'
    angular.module('rcmApp', ['ngMaterial'])
    .controller('rcmCtrl', function($scope, $http) {
        $scope.info = {};
        $scope.showGames = function() {
            $http({
                method: 'POST',
                url: '/getGamesList',

            }).then(function(response) {
                $scope.games = response.data;
                console.log('mm', $scope.games);
            }, function(error) {
                console.log(error);
            });
        }

        $scope.showGames();
    })

    .controller('SelectAsyncController', function($timeout, $scope) {
      $scope.dev = null;
      $scope.devs = null;

      $scope.loadDevs = function() {

        // Use timeout to simulate a 650ms request.
        return $timeout(function() {

          $scope.devs =  $scope.devs  || [
            { id: 1, dev: 'Scooby Doo' },
            { id: 2, dev: 'Shaggy Rodgers' },
            { id: 3, dev: 'Fred Jones' },
            { id: 4, dev: 'Daphne Blake' },
            { id: 5, dev: 'Velma Dinkley' }
          ];

        }, 650);
      };
}());