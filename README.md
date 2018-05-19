# Task Manager

### Build & Run with Docker:

#### Development
```bash
docker build -t task_manager_dev . && \
docker run -it -p 3000:3000 --name task_manager_dev task_manager_dev
```

#### Test (RSpec)
```bash
docker build --build-arg RAILS_ENV=test -t task_manager_test . && \
docker run --rm task_manager_test bin/rails spec
```

#### Production
```bash
docker build -t task_manager_prod --build-arg RAILS_ENV=production . && \
docker run -it -p 3000:3000 --name task_manager_prod task_manager_prod
```