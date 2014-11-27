    
app.factory('Visualisation', ['$resource',
    function($resource){
        return $resource('visualisations/:id.json', {id : "@id"}, {
            query: { method:'GET', url:'visualisations.json', isArray:true },
            approve: { method:'PATCH', url:'visualisations/:id/approve.json'},
            reject: { method:'PATCH', url:'visualisations/:id/reject.json'}
        });
}]);

app.factory('Timeslot', ['$resource',
    function($resource){
        return $resource('timeslots/:id.json', {id:"@id"}, {
            query: { method:'GET', url: 'timeslots.json', isArray:true },
            new:   { method:'POST', url: 'timeslots.json', responseType: 'json'},
            remove:{ method:'DELETE', responseType: 'json'},
            update:{ method:'PATCH', responseType: 'json'},
        });
}]);