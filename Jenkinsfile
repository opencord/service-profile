node ('build') {
    stage('Config') {
        sh '$TARGET_MACHINE_SSH_COMMAND "\
        cd ~/service-profile; \
        echo $GERRIT_BRANCH; \
        git checkout $GERRIT_BRANCH" '
    }
    stage('Build') {
        sh '$TARGET_MACHINE_SSH_COMMAND "\
        cd ~/service-profile/frontend; \
        make rm; \
        make local_containers; \
        make" '
    }
    stage('Test') {
        sh '$TARGET_MACHINE_SSH_COMMAND "\
        cd ~/cord-tester/src/test/cord-api/Properties/; \
        cp RestApiProperties.py RestApiProperties.py.copy; \
        sed -i $SET_SERVER_IP_COMMAND RestApiProperties.py; \
        sed -i $SET_SERVER_PORT_COMMAND RestApiProperties.py; \
        cd ~/cord-tester/src/test/cord-api/Tests/; \
        rm -r ../Log; \
        pybot -d ../Log -T ServiceTest.txt; \
        pybot -d ../Log -T Users.txt; \
        pybot -d ../Log -T UtilsSynchronizer.txt; \
        cd ~/cord-tester/src/test/cord-api/Properties/; \
        mv RestApiProperties.py.copy RestApiProperties.py; \" '
    }
    stage('Publish') {
        sh 'rm -r RobotLogs; mkdir RobotLogs'
        sh 'sshpass -p $TARGET_MACHINE_PASSWORD scp -r $TARGET_MACHINE_USERNAME@$TARGET_MACHINE_IP:~/cord-tester/src/test/cord-api/Log/* ./RobotLogs'
        step([$class: 'RobotPublisher',
            disableArchiveOutput: false,
            logFileName: 'RobotLogs/log*.html',
            otherFiles: '',
            outputFileName: 'RobotLogs/output*.xml',
            outputPath: '.',
            passThreshold: 100,
            reportFileName: 'RobotLogs/report*.html',
            unstableThreshold: 0]);
    }
}
