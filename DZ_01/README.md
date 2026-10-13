# Урок 1 — Объекты в Kubernetes

Источник: презентация OTUS «Объекты в Kubernetes», 44 слайда (предоставлена на занятии).

## Программа

1. Pod; метки (Labels) и селекторы (Selectors).
2. ReplicaSet.
3. DaemonSet.
4. Deployment: обновления RollingUpdate и Recreate; откат.
5. StatefulSet и отличие от Deployment.
6. Service и Port Forwarding.
7. Dashboard (дополнительная тема).

## ДЗ-1 (дословный смысл слайда 39)

1. Установить Minikube.
2. Создать Pod с Nginx и применить манифест.
3. Проверить статус Pod.
4. Создать Deployment с 3 репликами Nginx.
5. Масштабировать Deployment до 5 реплик и проверить.
6. Обновить образ Nginx до версии 1.28.

## Порядок работы

- Проверить Windows, Docker, kubectl, minikube перед установкой.
- Работать в отдельном учебном namespace `otus-k8s-dz01`.
- Сохранять YAML-манифесты в `DZ_01/manifests/`.
- Выполнить команды и сохранить результаты проверок в `DZ_01/evidence/` (без паролей, токенов и персональных данных).
- Соотнести результат с OTUS AI Architect ДЗ-18 (IaC и CI/CD), **не подменяя задания друг другом**.

## Критерии приёмки

- `minikube status` показывает рабочий кластер.
- Pod `nginx-pod` в состоянии Running.
- Deployment `nginx-deployment` создаёт 3 готовые реплики.
- После масштабирования 5/5 реплик готовы.
- После обновления Deployment использует `nginx:1.28`, rollout успешен, 5/5 реплик готовы.

## Начало лабораторной

Открыть PowerShell:

```powershell
docker --version
docker info
kubectl version --client
minikube version
wsl --status
```

После диагностики выбрать Minikube driver. Не изменять существующий Docker/Kubernetes-контур FATHER без проверки.
