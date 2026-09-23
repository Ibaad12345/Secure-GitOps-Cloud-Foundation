FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 1. Create a dedicated non-root group and user with explicit UID/GID
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -M appuser

WORKDIR /app

# 2. Copy dependency file and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy application files and grant read-only ownership to appuser
COPY --chown=appuser:appgroup . .

# 4. Switch from root to unprivileged user
USER 10001

EXPOSE 8000

CMD ["uvicorn", "app-test.app:app", "--host", "0.0.0.0", "--port", "8000"]