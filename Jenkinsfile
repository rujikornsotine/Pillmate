// Jenkins Declarative Pipeline สำหรับ build แอป Pillmate (Flutter) บน Windows agent
//
// วิธีตั้งค่า Jenkins job:
//   1. New Item -> Pipeline
//   2. Pipeline -> Definition: "Pipeline script from SCM"
//   3. SCM: Git, Repository URL: https://github.com/rujikornsotine/Pillmate.git
//   4. Branch: */main, Script Path: Jenkinsfile
//
// ข้อกำหนดของ agent (Windows):
//   - ติดตั้ง Flutter SDK และ Android SDK แล้ว
//   - accept Android SDK licenses แล้ว (flutter doctor --android-licenses)
//   - user ที่รัน Jenkins service ต้องเข้าถึง Flutter/Android SDK ได้

pipeline {
    agent any

    environment {
        // Jenkins service บน Windows มักไม่เห็น flutter ใน PATH ของ user ที่ล็อกอิน
        // ปรับ path นี้ให้ตรงกับตำแหน่งที่ติดตั้ง Flutter SDK บน agent
        PATH = "C:\\src\\flutter\\bin;${PATH}"
    }

    parameters {
        choice(
            name: 'BUILD_MODE',
            choices: ['release', 'debug'],
            description: 'โหมดการ build APK'
        )
        booleanParam(
            name: 'OBFUSCATE',
            defaultValue: false,
            description: 'obfuscate โค้ด Dart (ใช้กับโหมด release เท่านั้น)'
        )
    }

    options {
        timestamps()
        // กัน 2 build รันชน workspace เดียวกัน (Flutter/Gradle จะ lock ไฟล์)
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }

    stages {
        stage('Environment') {
            steps {
                bat 'flutter --version'
            }
        }

        stage('Dependencies') {
            steps {
                bat 'flutter pub get'
            }
        }

        stage('Analyze') {
            steps {
                // --no-fatal-infos: ไม่ให้ lint ระดับ info ทำให้ build ล้มเหลว
                // (warning/error ยังทำให้ล้มเหลวตามปกติ)
                bat 'flutter analyze --no-fatal-infos'
            }
        }

        stage('Test') {
            steps {
                bat 'flutter test'
            }
        }

        stage('Build APK') {
            steps {
                script {
                    def cmd = "flutter build apk --${params.BUILD_MODE}"
                    if (params.BUILD_MODE == 'release' && params.OBFUSCATE) {
                        cmd += ' --obfuscate --split-debug-info=build/app/outputs/symbols'
                    }
                    bat cmd
                }
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts(
                    artifacts: "build/app/outputs/flutter-apk/app-${params.BUILD_MODE}.apk",
                    fingerprint: true
                )
                // เก็บ debug symbols ไว้ decode stack trace เมื่อ obfuscate
                archiveArtifacts(
                    artifacts: 'build/app/outputs/symbols/*.symbols',
                    fingerprint: true,
                    allowEmptyArchive: true
                )
            }
        }
    }

    post {
        success {
            echo "Build สำเร็จ: app-${params.BUILD_MODE}.apk"
        }
        failure {
            echo 'Build ล้มเหลว ตรวจสอบ log ด้านบน'
        }
    }
}
