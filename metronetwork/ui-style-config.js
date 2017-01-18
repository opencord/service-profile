angular.module('app')
  .constant('StyleConfig', {
    projectName: 'E-CORD',
    favicon: 'cord-favicon.png',
    background: 'cord-bg.jpg',
    payoff: 'Enterprise on demand',
    logo: 'cord-logo.png',
    routes: [
        {
            label: 'Slices',
            state: 'xos.core.slices'
        },
        {
            label: 'Instances',
            state: 'xos.core.instances'
        },
        {
            label: 'Nodes',
            state: 'xos.core.nodes'
        }
    ]
});
