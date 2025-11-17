import { useState } from 'react';
import { useAISuggestions } from '@/domain/aiAutomation/hooks/useAISuggestions';
import { useAutomationRules } from '@/domain/aiAutomation/hooks/useAutomationRules';
import { SuggestionCard } from '@/domain/aiAutomation/components/SuggestionCard';
import { AutomationRuleCard } from '@/domain/aiAutomation/components/AutomationRuleCard';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';

const AIAutomationPage = () => {
  const [activeTab, setActiveTab] = useState<'suggestions' | 'rules'>('suggestions');

  const {
    suggestions,
    isLoading: suggestionsLoading,
    acceptSuggestion,
    rejectSuggestion,
    isAccepting,
    isRejecting,
  } = useAISuggestions();

  const {
    rules,
    isLoading: rulesLoading,
    deleteRule,
    toggleRule,
    isDeleting,
    isToggling,
  } = useAutomationRules();

  const handleEditRule = (ruleId: string) => {
    console.log('Edit rule:', ruleId);
  };

  const handleToggleRule = async (ruleId: string, isActive: boolean) => {
    await toggleRule({ ruleId, isActive });
  };

  const pendingSuggestions = suggestions.filter((s) => s.status === 'PENDING');

  return (
    <div className="max-w-6xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">AI Automation</h1>
        <p className="text-muted-foreground">
          Manage AI-powered suggestions and automation rules to optimize your workflow
        </p>
      </div>

      <div className="border-b mb-6">
        <div className="flex gap-4">
          <button
            onClick={() => setActiveTab('suggestions')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              activeTab === 'suggestions'
                ? 'border-primary text-primary'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Suggestions ({pendingSuggestions.length})
          </button>
          <button
            onClick={() => setActiveTab('rules')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              activeTab === 'rules'
                ? 'border-primary text-primary'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Automation Rules ({rules.length})
          </button>
        </div>
      </div>

      {activeTab === 'suggestions' && (
        <div>
          {suggestionsLoading ? (
            <LoadingSpinner />
          ) : pendingSuggestions.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-muted-foreground">No pending suggestions at the moment</p>
            </div>
          ) : (
            <div className="space-y-4">
              {pendingSuggestions.map((suggestion) => (
                <SuggestionCard
                  key={suggestion.suggestion_id}
                  suggestion={suggestion}
                  onAccept={acceptSuggestion}
                  onReject={rejectSuggestion}
                  isAccepting={isAccepting}
                  isRejecting={isRejecting}
                />
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === 'rules' && (
        <div>
          <div className="flex justify-end mb-4">
            <button className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 font-medium">
              Create New Rule
            </button>
          </div>

          {rulesLoading ? (
            <LoadingSpinner />
          ) : rules.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-muted-foreground">No automation rules configured yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {rules.map((rule) => (
                <AutomationRuleCard
                  key={rule.automation_rule_id}
                  rule={rule}
                  onEdit={handleEditRule}
                  onDelete={deleteRule}
                  onToggle={handleToggleRule}
                  isDeleting={isDeleting}
                  isToggling={isToggling}
                />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default AIAutomationPage;
