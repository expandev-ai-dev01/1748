import { authenticatedClient } from '@/core/lib/api';
import type {
  AISuggestion,
  AutomationRule,
  CreateAutomationRuleDto,
  UpdateAutomationRuleDto,
  DelegationSuggestion,
  TaskOptimization,
  AIFeedback,
} from '../types';

export const aiAutomationService = {
  async getSuggestions(): Promise<AISuggestion[]> {
    const response = await authenticatedClient.get('/ai-automation/suggestions');
    return response.data.data;
  },

  async acceptSuggestion(suggestionId: string): Promise<void> {
    await authenticatedClient.post(`/ai-automation/suggestions/${suggestionId}/accept`);
  },

  async rejectSuggestion(suggestionId: string): Promise<void> {
    await authenticatedClient.post(`/ai-automation/suggestions/${suggestionId}/reject`);
  },

  async listAutomationRules(): Promise<AutomationRule[]> {
    const response = await authenticatedClient.get('/ai-automation/rules');
    return response.data.data;
  },

  async getAutomationRule(ruleId: string): Promise<AutomationRule> {
    const response = await authenticatedClient.get(`/ai-automation/rules/${ruleId}`);
    return response.data.data;
  },

  async createAutomationRule(data: CreateAutomationRuleDto): Promise<AutomationRule> {
    const response = await authenticatedClient.post('/ai-automation/rules', data);
    return response.data.data;
  },

  async updateAutomationRule(
    ruleId: string,
    data: UpdateAutomationRuleDto
  ): Promise<AutomationRule> {
    const response = await authenticatedClient.put(`/ai-automation/rules/${ruleId}`, data);
    return response.data.data;
  },

  async deleteAutomationRule(ruleId: string): Promise<void> {
    await authenticatedClient.delete(`/ai-automation/rules/${ruleId}`);
  },

  async toggleAutomationRule(ruleId: string, isActive: boolean): Promise<AutomationRule> {
    const response = await authenticatedClient.patch(`/ai-automation/rules/${ruleId}/toggle`, {
      is_active: isActive,
    });
    return response.data.data;
  },

  async getDelegationSuggestions(
    taskTitle: string,
    taskDescription?: string
  ): Promise<DelegationSuggestion[]> {
    const response = await authenticatedClient.post('/ai-automation/delegation/suggest', {
      task_title: taskTitle,
      task_description: taskDescription,
    });
    return response.data.data;
  },

  async optimizeTask(taskId: string): Promise<TaskOptimization> {
    const response = await authenticatedClient.post(`/ai-automation/tasks/${taskId}/optimize`);
    return response.data.data;
  },

  async submitFeedback(
    suggestionId: string,
    wasHelpful: boolean,
    correctionPayload?: Record<string, unknown>
  ): Promise<AIFeedback> {
    const response = await authenticatedClient.post('/ai-automation/feedback', {
      source_suggestion_id: suggestionId,
      was_suggestion_helpful: wasHelpful,
      correction_payload: correctionPayload,
    });
    return response.data.data;
  },
};
