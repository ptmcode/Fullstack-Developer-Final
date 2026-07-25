pipeline {
    agent any
    
    environment {
        // Server Configuration
        TARGET_SERVER = '62.146.239.183'
        USER = 'root'
        ROOT_DIR = '/opt/projects/teach'
        PROJECT_FOLDER = 'springboot-jwt-api'
        REPOSITORY_URL = 'https://github.com/dinsarendev/springboot-jwt-api.git'
        
        // Full paths
        PROJECT_PATH = "${ROOT_DIR}/${PROJECT_FOLDER}"
        SSH_CREDENTIALS = 'jenkins-ssh-key'
    }
    
    parameters {
        gitParameter(
            name:           'BRANCH',
            type:           'PT_BRANCH',
            branchFilter:   'origin/(.*)',
            defaultValue:   'main',
            selectedValue:  'DEFAULT',
            sortMode:       'DESCENDING_SMART',
            description:    'Choose a branch to checkout'
        )
    }
    
    stages {
        stage('Pre-flight Checks') {
            steps {
                script {
                    echo ""
                    echo "🚀 =================================="
                    echo "   API DEPLOYMENT PIPELINE STARTED"
                    echo "======================================"
                    echo ""
                    echo "Configuration Details:"
                    echo "  📡 Target Server : ${TARGET_SERVER}"
                    echo "  👤 User         : ${USER}"
                    echo "  🌿 Branch       : ${params.BRANCH}"
                    echo "  📦 Repository   : ${REPOSITORY_URL}"
                    echo ""
                    echo "======================================"
                    echo ""
                }
            }
        }

        stage('Checkout Latest Code') {
            steps {
                script {
                    echo "📥 Checking out latest code from branch: ${params.BRANCH}"
                    sshagent(credentials: [SSH_CREDENTIALS]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${USER}@${TARGET_SERVER} '
                                # Check if project directory exists, if not clone the repository
                                if [ ! -d "${PROJECT_PATH}" ]; then
                                    echo "❌ Project directory not found. Cloning repository..."
                                    mkdir -p ${ROOT_DIR}
                                    cd ${ROOT_DIR}
                                    git clone ${REPOSITORY_URL} ${PROJECT_DIR}
                                fi
                                
                                # Navigate to the project folder inside the cloned repository
                                cd ${PROJECT_PATH} || {
                                    echo "❌ Project folder ${PROJECT_FOLDER} not found in repository"
                                    exit 1
                                }
                                
                                echo "📂 Current directory: \$(pwd)"
                                echo "🔍 Current git status:"
                                git status
                                
                                echo "🔄 Fetching latest changes..."
                                git fetch origin
                                
                                echo "🌿 Checking out branch: ${params.BRANCH}"
                                git checkout ${params.BRANCH}
                                
                                echo "⬇️ Pulling latest changes..."
                                git pull origin ${params.BRANCH}
                                
                                echo "✅ Current commit:"
                                git log --oneline -1
                                
                                echo "📋 Branch information:"
                                git branch -v
                                
                                echo "📁 Project structure:"
                                ls -la
                            '
                        """
                    }
                }
            }
        }
        
        stage('Build and Deploy') {
            steps {
                script {
                    echo "🔨 Building with latest code from branch: ${params.BRANCH}"
                    sshagent(credentials: [SSH_CREDENTIALS]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${USER}@${TARGET_SERVER} '
                                cd ${PROJECT_PATH} || exit 1
                                
                                echo "🌐 Deploying"
                                docker compose -f docker-compose.yml build  --no-cache

                                echo "🔨 Building"
                                docker compose -f docker-compose.yml up -d

                                
                                echo "⏳ Waiting for containers to be ready..."
                                sleep 15
                                
                                echo "✅ Deployment status:"
                                docker compose ps
                                
                                echo "📋 Recent logs:"
                                docker compose logs --tail=20

                                echo "🧹 Cleaning up old images..."
                                docker image prune -f
                            '
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline executed successfully!"
            echo "🎉 Branch ${params.BRANCH} deployed to ${TARGET_SERVER}"
            echo "📊 Final deployment summary:"
        }
        failure {
            echo "❌ Pipeline failed!"
            echo "🔍 Check the logs above for error details"
        }
    }
}
